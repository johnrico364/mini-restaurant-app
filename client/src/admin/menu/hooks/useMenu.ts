import { useQuery } from "@tanstack/react-query";
import axios from "axios";

export const useMenu = () => {
  return useQuery({
    queryKey: ["menu"],
    queryFn: async () => {
      const { data } = await axios.get(
        "https://my-json-server.typicode.com/johnrico364/mini-restaurant-app/menu"
      );

      return data;
    },
  });
};
